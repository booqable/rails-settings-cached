module RailsSettings
  class CachedSettings < Settings

    class_attribute :_cache_scope

    class << self

      def cache_scope(cache_scope=nil)
        if cache_scope
          self._cache_scope = cache_scope
        else
           _cache_scope.is_a?(Proc) ?  _cache_scope.call(self) :  _cache_scope
        end
      end

    end

    after_commit :rewrite_cache, on: [:create, :update]
    def rewrite_cache
      Rails.cache.write("#{cache_scope}.settings:#{self.var}", self.value)
    end

    after_commit :expire_cache, on: [:destroy]
    def expire_cache
      Rails.cache.delete("#{cache_scope}.settings:#{self.var}")
    end

    def self.[](var_name)
      cache_key = "#{cache_scope}.settings:#{var_name}"
      obj = Rails.cache.read(cache_key)
      if obj == nil
        obj = super(var_name)
      end

      return @@defaults[var_name.to_s] if obj == nil
      obj
    end

    def self.save_default(key,value)
      return false if self.send(key) != nil
      self.send("#{key}=",value)
    end

    def cache_scope
      self.class.cache_scope
    end

  end
end
