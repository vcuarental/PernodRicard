public virtual with sharing class ASI_MFM_SG_FullCalendarEvent {
	public String id { get; set; }
	public String title { get; set; }
	public String startStr { get; private set; }
	public Datetime startDT { get; set {startDT = value; startStr = value.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');} }
	public String endStr { get; private set; }
	public Datetime endDT { get; set {endDT = value; endStr = value.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');} }
	public Boolean allDay { get; set; }
	public String className { get; set; }
	public Boolean editable { get; set; }
	public String backgroundColor { get { if (backgroundColor == null) backgroundColor = '#6777CC'; return backgroundColor; } set; }
	public String textColor { get { if (textColor == null) textColor = '#FFFFFF'; return textColor; } set; }
	//public String borderColor { get { if (borderColor == null) borderColor = '#6777CC'; return borderColor; } set; }
}