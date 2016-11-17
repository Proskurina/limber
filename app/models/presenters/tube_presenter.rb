# frozen_string_literal: true

module Presenters
  class TubePresenter
    def qc_owner
      labware
    end

    include Presenter
    include Statemachine::Shared
    include RobotControlled

    class_attribute :labware_class
    self.labware_class = :tube

    self.attributes =  [:api, :labware]

    class_attribute :additional_creation_partial
    self.additional_creation_partial = 'labware/tube/child_tube_creation'

    class_attribute :tab_states

    LABEL_TEXT = 'ILB Stock'

    def label_text
      "#{labware.label.prefix} #{labware.label.text || LABEL_TEXT}"
    end

    def label_name
      "#{labware.barcode.prefix} #{labware.barcode.number}"
    end

    def control_child_links(&block)
      # Mostly, no.
    end

    # The state is delegated to the tube
    delegate :state, to: :labware

    def label_description
      "#{prioritized_name(labware.name, 10)} #{label_text}"
    end

    def sample_count
      labware.aliquots.count
    end

    def label_suffix
      "P#{sample_count}"
    end

    # Purpose returns the plate or tube purpose of the labware.
    # Currently this needs to be specialised for tube or plate but in future
    # both should use #purpose and we'll be able to share the same method for
    # all presenters.
    delegate :purpose, to: :labware

    def labware_form_details(view)
      { url: view.limber_tube_path(labware), as: :tube }
    end

    class UnknownTubeType < StandardError
      attr_reader :tube

      def initialize(tube)
        super("Unknown plate type #{tube.purpose.name.inspect}")
        @tube = tube
      end
    end

    def self.lookup_for(labware)
      (presentation_classes = Settings.purposes[labware.purpose.uuid]) || raise(UnknownTubeType, labware)
      presentation_classes[:presenter_class].constantize
    end
  end
end
