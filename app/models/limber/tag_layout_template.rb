# frozen_string_literal: true
# This file is part of Illumina-B Pipeline is distributed under the terms of GNU General Public License version 3 or later;
# Please refer to the LICENSE and README files for information on licensing and authorship of this file.
# Copyright (C) 2012 Genome Research Ltd.
class Limber::TagLayoutTemplate < Sequencescape::TagLayoutTemplate
  # Performs the coercion of this instance so that it behaves appropriately given the direction
  # and walking algorithm information.
  def coerce
    extend("limber/tag_layout_template/in_#{direction.gsub(/\s+/, '_')}s".camelize.constantize)
    extend("limber/tag_layout_template/walk_#{walking_by.gsub(/\s+/, '_')}".camelize.constantize)
    self
  end

  # This returns an array of well location to pool pairs.  The 'walker' is responsible for actually doing the walking
  # of the wells that are acceptable, and it calls back with the location of the well being processed.
  def group_wells(plate)
    well_to_pool = Hash[plate.wells.map { |well| [well.location, well.pool_id] }]

    # We assume that if a well is unpooled then it is in the same pool as the previous pool.
    prior_pool = nil
    callback = lambda do |row, column|
      prior_pool = pool = (well_to_pool["#{row}#{column}"] || prior_pool) # or next
      emptiness = well_to_pool["#{row}#{column}"].nil?
      well = pool.nil? ? nil : "#{row}#{column}"
      [well, pool, emptiness] # Triplet: [ A1, pool_id, emptiness ]
    end
    yield(callback)
  end
  private :group_wells

  def tag_ids
    tag_group.tags.keys.map!(&:to_i).sort
  end
  private :tag_ids
end
