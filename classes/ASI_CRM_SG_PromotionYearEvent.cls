public with sharing class ASI_CRM_SG_PromotionYearEvent implements Comparable {
        public ID sObjId { get; set; }
        public Object groupValue { get; set; }
        public String title { get; set; }
        public Date startDate { get; set; }
        public Date endDate { get; set; }
        public String popupId { get; set; }
        public String topPos { get; set; }
        public String leftPos { get; private set; }
        public String width { get; private set; }
        public String height { get; private set; }
        public String color { get {if (color == null) color = '#FFFFFF'; return color; } set; }
        public String backgroundColor { get {if (backgroundColor == null) backgroundColor = '#6777CC'; return backgroundColor; } set; }
        
        public void setLayout(Date fromDate, Date toDate, Integer initLeft, Integer monthWidth, Integer eventHeight, Integer beginXSpace, Integer endXSpace) {
            startDate = fromDate > startDate ? fromDate : startDate;
            endDate = toDate < endDate ? toDate : endDate;
            leftPos = String.valueOf(initLeft + (fromDate.monthsBetween(startDate) * monthWidth) + beginXSpace) + 'px';
            width = String.valueOf(((startDate.monthsBetween(endDate) + 1) * monthWidth) - beginXSpace - endXSpace) + 'px';
            height = String.valueOf(eventHeight) + 'px';
        }
        
        public Integer compareTo(Object objectToCompareTo) {
            Date compareToStartDate = ((ASI_CRM_SG_PromotionYearEvent)objectToCompareTo).startDate;
            if (startDate == null || compareToStartDate == null) {
                if (startDate == compareToStartDate) return 0;
                return startDate == null ? -1 : 1;
            } else if (startDate > compareToStartDate) {
                return 1;
            } else if (startDate < compareToStartDate) {
                return -1;
            } else if (startDate == compareToStartDate) {
                return 0;
            }
            return null;
        }
    }