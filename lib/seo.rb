module Seo
  module Controller
    module ClassMethods
      def title(title, only_seo = false)
        before_filter {|c| c.send :title, title, only_seo }
      end
      %w(seo_keywords seo_description).each do |m|
        define_method m do |param|
          before_filter {|c| c.send(m, param)}
        end
      end
    end
    
    extend ClassMethods
    
    def self.included(controller)
      controller.class_eval do
        extend(ClassMethods)
        helper_method :title, :seo_object, :seo_title, :seo_description, :seo_keywords
      end
    end

  protected
    def title(page_title, only_seo = false)
      case only_seo
        when false
          @page_title = page_title
        when true
          @seo_title  = page_title
        when String
          @page_title = page_title
          @seo_title  = only_seo
      end
    end

    def seo_title(title)
      @seo_title = title
    end

    def seo_keywords(words = nil)
      words = words * ', ' if words.is_a?(Array)
      @seo_keywords ||= []
      @seo_keywords << words unless words.nil?
      @seo_keywords
    end

    def seo_description(desc = nil)
      @seo_description = desc unless desc.nil?
      @seo_description
    end

    def seo_object(object)
      %w(seo_title seo_keywords seo_description).each do |method|
        send(method, object.send(method)) if object.respond_to?(method)
      end
    end
  end

  module Helpers
    def seo_block
      content_tag(:title, @content_for_title || @seo_title || @page_title) +
        tag(:meta, :name => 'description', :content => seo_description) +
        tag(:meta, :name => 'keywords', :content => (seo_keywords.compact.flatten * ', '))
    end
  end
end
