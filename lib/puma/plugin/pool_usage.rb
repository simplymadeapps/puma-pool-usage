# frozen_string_literal: true

require "json"
require "puma/plugin"
require "rails"

# Plugin that outputs pool usage into Rails logs.
# Usage expressed via a percentage of your available resources as a float.
#
# @example when running in cluster mode (pid is logged)
#   source=PUMA pid=123456 sample#puma.pool_usage=0.8
#
# @example when not running in cluster mode (pid is logged as 0)
#   source=PUMA pid=0 sample#puma.pool_usage=0.5
Puma::Plugin.create do
  # Method called by Puma on startup.
  #
  # @param [Puma::Launcher] _launcher Puma launcher object, ignored.
  def start(_launcher)
    in_background do
      loop do
        sleep ENV.fetch("PUMA_STATS_FREQUENCY", 60).to_i
        find_and_log_pool_usage
        Rails.logger.flush
      end
    end
  end

  private

  # Find the Puma stats necessary depending on mode (single vs. cluster).
  # Sends statistics for logging.
  def find_and_log_pool_usage
    stats = JSON.parse(Puma.stats, symbolize_names: true)

    if stats[:worker_status]
      stats[:worker_status].each { |worker| log_pool_usage(worker[:last_status], pid: worker[:pid]) }
    else
      log_pool_usage(stats, pid: 0)
    end
  end

  # Calculate and log, assuing Puma has started and provided stats.
  #
  # @param [Hash] status Puma statistics.
  # @param [Integer] pid Process identifier for this particular Puma worker.
  def log_pool_usage(status, pid:)
    return if status[:pool_capacity].nil?

    pool_usage = (status[:running] - (status[:pool_capacity] - status[:backlog])) / status[:running].to_f
    Rails.logger.info "source=PUMA pid=#{pid} sample#puma.pool_usage=#{pool_usage}"
  end
end
