#encoding: utf-8

module Visjar
  class Log
    @before = []
    class << self
      def debug(message, timed = :none)
        log(:debug, message, timed)
      end

      def info(message, timed = :none)
        log(:info, message, timed)
      end

      def warn(message, timed = :none)
        log(:warn, message, timed)
      end

      def error(message, timed = :none)
        log(:error, message, timed)
      end

      def fatal(message, timed = :none)
        log(:fatal, message, timed)
      end

      private
      def log(level, message, timed)
        return if DaemonKit.test?

        if timed == :begin
          @before.push(Time.now)
        elsif timed == :end and @before.any?
          message << " (#{(Time.now - @before.shift).round(4)}s)"
        end

        if DaemonKit.logger.nil?
          puts "[#{level.to_s}] #{message}"
        else
          DaemonKit.logger.send(level.to_sym, ActiveSupport::Inflector.transliterate("#{message}", "x"))
        end
      end
    end
  end
end
