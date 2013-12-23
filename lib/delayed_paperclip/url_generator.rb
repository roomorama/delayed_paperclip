require 'uri'

module DelayedPaperclip
  module UrlGenerator
    def self.included(base)
      base.alias_method_chain :most_appropriate_url, :processed
      base.alias_method_chain :timestamp_possible?, :processed
      base.alias_method_chain :for, :processed
    end

    def for_with_processed(style_name, options)
      escape_url_as_needed(
        timestamp_as_needed(
            @attachment_options[:interpolator].interpolate(most_appropriate_url(style_name_with_processed), @attachment, style_name),
            options
        ), options)
    end

    def most_appropriate_url_with_processed(style = nil)
      if (@attachment.original_filename.nil? || delayed_default_url?) && !@attachment.split_processing?
        if @attachment.delayed_options.nil? || @attachment.processing_image_url.nil? || !@attachment.processing?
          default_url
        else
          @attachment.processing_image_url
        end
      else
        if style && @attachment.only_process.include?(style) || !@attachment.job_is_processing # Return the regular URL if the style is included in the list to generate immediately, or the image has finished processing.
          @attachment_options[:url]
        else
          @attachment.processing_image_url
        end
      end
    end

    def timestamp_possible_with_processed?
      if delayed_default_url?
        false
      else
        timestamp_possible_without_processed?
      end
    end

    def delayed_default_url?
      return false if @attachment.job_is_processing
      return false if @attachment.dirty?
      return false if not @attachment.delayed_options.try(:[], :url_with_processing)
      return false if not (@attachment.instance.respond_to?(:"#{@attachment.name}_processing?") && @attachment.processing?)
      true

      # OLD CRAZY CONDITIONAL
      # TODO: Delete
      # !(
      #   @attachment.job_is_processing ||
      #   @attachment.dirty? ||
      #   !@attachment.delayed_options.try(:[], :url_with_processing) ||
      #   !(@attachment.instance.respond_to?(:"#{@attachment.name}_processing?") && @attachment.processing?)
      # )
    end
  end

end
