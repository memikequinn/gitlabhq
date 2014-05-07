require 'sys/filesystem'
class Vapor < ActiveRecord::Base
  class PathNotFoundError < StandardError;
  end
  include Sys
  attr_accessible :path, :tier, :default
  has_many :projects
  validates :path, uniqueness: true, presence: true
  before_update :update_when_new_default
  before_create :ensure_dir_exists
  before_destroy :move_off_projects
  after_initialize :set_defaults
  scope :tier, ->(tier) { where(tier: tier) }
  scope :default, -> { where(default: true).first }

  def big_enough
    Vapor.all.select { |v| (v.free_space > usage && v != self) rescue false }.first
  end

  def free_space
    begin
      stat = Filesystem.stat(path)
      (stat.block_size * stat.blocks_available)
    rescue Sys::Filesystem::Error
      Rails.logger.warn "Could not get file system disk usage: #{$!}"
    end
  end

  def ensure_dir_exists
    Rails.logger.info "Adding vapor path... checking if #{self.path} exists"
    unless Dir.exists?(self.path)
      self.errors.add(:base, "Could not find the file system #{self.path}")
      raise PathNotFoundError.new "Could not find the path #{self.path}"
    end
    true
  rescue
    false
  end

  def usage
    projects.collect { |p| p.repository.size rescue 0 }.compact.inject(:+) || 0
  end

  def usage_mb
    usage * 1024 * 1024
  end

  private
  def update_when_new_default
    # Use update_column to skip callbacks
    if Vapor.where(default: true).count > 0
      Vapor.default.update_column :default, false
    end
  end

  private
  def move_off_projects
    projects.each do |project|
      Vapors::MoveService.new(big_enough).move(project)
    end
  end

  def set_defaults
    self.tier    ||= 1
    self.default ||= false
  end

end
