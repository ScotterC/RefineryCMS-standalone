module Refinery
  class Configuration

    def after_inclusion_procs
      @@after_inclusion_procs ||= []
    end

    def after_inclusion(&blk)
      if blk && blk.respond_to?(:call)
        after_inclusion_procs << blk
      else
        raise 'Anything added to be called before_inclusion must be callable.'
      end
    end

    def before_inclusion_procs
      @@before_inclusion_procs ||= []
    end

    def before_inclusion(&blk)
      if blk && blk.respond_to?(:call)
        before_inclusion_procs << blk
      else
        raise 'Anything added to be called before_inclusion must be callable.'
      end
    end

  end
end
