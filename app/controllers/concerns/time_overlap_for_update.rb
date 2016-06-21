module TimeOverlapForUpdate
  private
  def overlap_when_update? event
    event_overlap = EventOverlap.new(event)
    event_overlap.overlap?
  end
end
