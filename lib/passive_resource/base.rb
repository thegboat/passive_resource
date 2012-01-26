module PassiveResource
  class Base
    require 'active_support/core_ext/hash/indifferent_access'
    require 'active_support/json'
  
    HASH_METHODS = (ActiveSupport::HashWithIndifferentAccess.new.methods - Object.new.methods)
  
    def initialize(p = {})
      p = load_from_url(p) if p.is_a?(String)
      @seedling = ActiveSupport::HashWithIndifferentAccess.new(p)
    end
  
    def seed
      @seedling
    end
  
    def [](key)
      if self.class.nestable?(@seedling[key])
        @seedling[key] = self.class.new(@seedling[key])
      elsif self.class.enumerable?(@seedling[key])
        @seedling[key] = self.class.many(@seedling[key])
      end
      @seedling[key]
    end
  
    def self.many(ary)
      ary = [ary].compact.flatten
      ary.collect {|hash| nestable?(hash) ? new(hash) : hash }
    end
  
    def method_missing(method_sym, *arguments, &block)
      accessor = method_sym.to_s.gsub(/\=$/,'')
      if @seedling.has_key?(accessor)
        accessor == method_sym.to_s ? self[accessor] : @seedling[accessor] = arguments.first
      elsif HASH_METHODS.include?(method_sym)
        @seedling.send(method_sym, *arguments, &block)
      else
        super
      end
    end
  
    def inspect
      @seedling.inspect
    end
    
    def load_from_url(url)
      rtn = RestClient.get(url)
      @seedling = JSON.parse(rtn)
    end
  
    private

    def self.nestable?(obj)
      ['ActiveSupport::HashWithIndifferentAccess', 'HashWithIndifferentAccess', 'Hash'].include?(obj.class.to_s)
    end
  
    def self.enumerable?(obj)
      ['Array', 'WillPaginate::Collection'].include?(obj.class.to_s)
    end
  end
end