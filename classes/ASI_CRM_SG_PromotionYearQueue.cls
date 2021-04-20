public with sharing class ASI_CRM_SG_PromotionYearQueue {
        public ASI_CRM_SG_PromotionYearGroup eventGroup { get; set; }
        public List<List<ASI_CRM_SG_PromotionYearEvent>> events { get; set; }
        
        public ASI_CRM_SG_PromotionYearQueue(ASI_CRM_SG_PromotionYearGroup eventGroup) {
            this(eventGroup, new List<ASI_CRM_SG_PromotionYearEvent>());
        }
        public ASI_CRM_SG_PromotionYearQueue(ASI_CRM_SG_PromotionYearGroup eventGroup, List<ASI_CRM_SG_PromotionYearEvent> events) {
            system.debug('@events'+events);
            system.debug('@eventGroup'+eventGroup);
            eventGroup = eventGroup;
            setEvents(events);
        }
        
        public void setEvents(List<ASI_CRM_SG_PromotionYearEvent> inputEvents) {
            events = new List<List<ASI_CRM_SG_PromotionYearEvent>>();
            inputEvents.sort();
            for (ASI_CRM_SG_PromotionYearEvent inputEvent : inputEvents) {
                Boolean foundEventLine = false;
                for (List<ASI_CRM_SG_PromotionYearEvent> eventLine : events) {
                    if (!isConflict(eventLine, inputEvent)) {
                        eventLine.add(inputEvent);
                        foundEventLine = true;
                        break;
                    }
                }
                if (!foundEventLine) {
                    List<ASI_CRM_SG_PromotionYearEvent> newEventLine = new List<ASI_CRM_SG_PromotionYearEvent>();
                    events.add(newEventLine);
                    newEventLine.add(inputEvent);
                }
            }
        }
        
        public Integer calculatePosition(Integer initTop, Integer incrementY) {
            for (List<ASI_CRM_SG_PromotionYearEvent> eventLine : events) {
                for (ASI_CRM_SG_PromotionYearEvent theEvent : eventLine) {
                    theEvent.topPos = '' + initTop + 'px';
                }
                initTop += incrementY;
            }
            return initTop;
        }
        
        public Boolean isConflict(List<ASI_CRM_SG_PromotionYearEvent> eventLine, ASI_CRM_SG_PromotionYearEvent checkEvent) {
            Integer eventLineSize = eventLine.size();
            for (Integer i = eventLineSize - 1; i >= 0; i--) {
                ASI_CRM_SG_PromotionYearEvent e = eventLine.get(i);
                if ((compareYearMonthOfTwoDate(e.startDate , checkEvent.startDate) >= 0 && compareYearMonthOfTwoDate(e.startDate, checkEvent.endDate) <= 0)
                    || (compareYearMonthOfTwoDate(e.endDate, checkEvent.startDate) >= 0 && compareYearMonthOfTwoDate(e.endDate, checkEvent.endDate) <= 0)
                    || (compareYearMonthOfTwoDate(e.startDate, checkEvent.startDate) <= 0 && compareYearMonthOfTwoDate(e.endDate, checkEvent.endDate) >= 0)) {
                    return true;
                }
            }
            return false;
        }
        
        public Integer compareYearMonthOfTwoDate(Date theDate1, Date theDate2) {
            if (theDate1.year() > theDate2.year()) {
                return 1;
            } else if (theDate1.year() < theDate2.year()) {
                return -1;
            } else { // if (theDate1.year() == theDate2.year())
                if (theDate1.month() > theDate2.month()) {
                    return 1;
                } else if (theDate1.month() < theDate2.month()) {
                    return -1;
                } else { // if (theDate1.month() == theDate2.month())
                    return 0;
                }
            }
        }
    }