module PassiveResource
  class Base
    require 'active_support/core_ext/hash/indifferent_access'
    require 'active_support/json'
    require 'rest_client'
  
    HASH_METHODS = (ActiveSupport::HashWithIndifferentAccess.new.methods - Object.new.methods)
  
    def initialize(p = {})
      p = load_from_url(p) if p.is_a?(String)
      if self.class.nestable?(p)
        @seedling = ActiveSupport::HashWithIndifferentAccess.new(p)
      elsif self.class.collection?(p)
        @seedling = self.class.many(p)
      else
        raise PassiveResource::InvalidSeedlingException, "A hash like object or a collection of hash like objects is required"
      end
    end
  
    def seedling
      @seedling
    end
    
    def id
      seedling.has_key?('id') ? seedling['id'] : super
    end
    
    def respond_to?(method)
      return true if super
      accessor = method.to_s.gsub(/\=$/,'')
      @seedling.has_key?(accessor) or HASH_METHODS.include?(method)
    end
  
    def [](key)
      if self.class.nestable?(@seedling[key])
        @seedling[key] = self.class.new(@seedling[key])
      elsif self.class.collection?(@seedling[key])
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
      JSON.parse(rtn)
    end

    def self.nestable?(obj)
      ['ActiveSupport::HashWithIndifferentAccess', 'HashWithIndifferentAccess', 'Hash'].include?(obj.class.to_s)
    end
  
    def self.collection?(obj)
      ['Array', 'WillPaginate::Collection'].include?(obj.class.to_s)
    end
  end
end