({
	init : function(cmp, event, helper) {
		var myPage = cmp.get("v.pageReference");
		cmp.set("v.noteId",myPage.state.c__nid);
		cmp.set("v.action",myPage.state.c__nid);
		cmp.set("v.visitId",myPage.state.c__vid);
		if(cmp.get("v.action") == 'Create Note')
		{
			cmp.set("v.note",{"Title":'',"Body":''});
			cmp.set("v.noteId",null);
		}
		else
		{
			cmp.set("v.action",'Update Note');
			helper.getNote(cmp,cmp.get("v.noteId"));
			
		}

	},

	saveNote : function (cmp,event,helper){
		helper.saveNote(cmp);
		$A.util.removeClass(cmp.find("customSpinner"), 'slds-hide');
	},

	backToVisitationDetail : function(cmp, event, helper) {
        var nav = cmp.find("navService");
		var vid = cmp.get("v.visitId");
		var nid = cmp.get("v.noteId");
		var pageReference = {
			type: 'standard__component',
			attributes: {
				componentName: 'c__ASI_CRM_VisitationPlanToday'
			}, 
			state: {
				c__id: vid,
				c__nid: nid
			}
		};

        nav.navigate(pageReference);
    }
})