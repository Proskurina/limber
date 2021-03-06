# frozen_string_literal: true
# This file is part of Illumina-B Pipeline is distributed under the terms of GNU General Public License version 3 or later;
# Please refer to the LICENSE and README files for information on licensing and authorship of this file.
# Copyright (C) 2012,2013 Genome Research Ltd.
class StateChangers::PlateToTubeStateChanger < StateChangers::QcCompletablePlateStateChanger
  def move_to!(state, reason, customer_accepts_responsibility = false)
    super
    create_stock_tubes! if state == 'qc_complete'
  end

  def create_stock_tubes!
    child_stock_tubes = api.tube_creation.create!(
      user: user_uuid,
      parent: labware_uuid,
      child_purpose: labware.plate_purpose.children.first.uuid
    ).children

    plate_to_tube_template.create!(
      user: user_uuid,
      source: labware_uuid,
      targets: child_stock_tubes.map(&:uuid)
    )
  end
  private :create_stock_tubes!

  def plate_to_tube_template
    api.transfer_template.find(
      Settings.transfer_templates['Transfer wells to specific tubes by submission']
    )
  end
  private :plate_to_tube_template
end
