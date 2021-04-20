({
	init : function(cmp, event, helper) {
		console.log('Ryan start');
		var myPage = cmp.get("v.pageReference");
		console.log(myPage.state.c__id);
		
		cmp.set("v.recordId",myPage.state.c__id);
		cmp.set("v.isStopped",myPage.state.c__isStopped);
		
		console.log(cmp.get("v.recordId"));
		console.log('Ryan End');
		helper.getCurrentVisitationPlanDetail(cmp,cmp.get("v.recordId"));
		cmp.set("v.section",'Q');
		//document.getElementById('Q').style.backgroundColor = '#033466';
		//document.getElementById('Q').style.color = 'white';
	},

	taskSelection : function(cmp, event, helper) {
		console.log(cmp.get("v.section"));
		if(cmp.get("v.section")=='Q')
		{
			cmp.set("v.visitationPlanDetail.ASI_MY_CRM_Bottle_Label__c",cmp.find("BottleLabel").get("v.value"));
			cmp.set("v.visitationPlanDetail.ASI_MY_CRM_Custody_Condition__c",cmp.find("CustodyCondition").get("v.value"));
			console.log(cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Bottle_Label__c"));
			console.log(cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Custody_Condition__c"));
		}
		if(cmp.get("v.section")=='V')
		{
			cmp.set("v.visitationPlanDetail.ASI_MY_CRM_Outlet_Type__c",cmp.find("OutletType").get("v.value"));
			cmp.set("v.visitationPlanDetail.ASI_MY_CRM_Follow_Plan__c",cmp.find("FollowPlan").get("v.value"));
			cmp.set("v.visitationPlanDetail.ASI_CRM_MY_BarDisplay__c",cmp.find("BarDisplay").get("v.value"));
			cmp.set("v.visitationPlanDetail.ASI_CRM_MY_Planogram__c",cmp.find("Planogram").get("v.value"));
			cmp.set("v.visitationPlanDetail.ASI_MY_CRM_Improvements__c",cmp.find("Improvements").get("v.value"));
			console.log(cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Outlet_Type__c"));
			console.log(cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Follow_Plan__c"));
			console.log(cmp.get("v.visitationPlanDetail.ASI_CRM_MY_BarDisplay__c"));
			console.log(cmp.get("v.visitationPlanDetail.ASI_CRM_MY_Planogram__c"));
			console.log(cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Improvements__c"));
		}
		if(cmp.get("v.section")=='A')
		{
			cmp.set("v.visitationPlanDetail.ASI_CRM_MY_Own_Activations__c",cmp.find("ownActivations").get("v.value"));
			cmp.set("v.visitationPlanDetail.ASI_CRM_MY_OwnActivationRemark__c",cmp.find("OwnActivationBrandNameRemarks").get("v.value"));
			console.log(cmp.get("v.visitationPlanDetail.ASI_CRM_MY_Own_Activations__c"));
			console.log(cmp.get("v.visitationPlanDetail.ASI_CRM_MY_OwnActivationRemark__c"));
		}
		if(cmp.get("v.section")=='P')
		{
			cmp.set("v.visitationPlanDetail.ASI_MY_CRM_Top_Of_Staff_Mind__c",cmp.find("topOfStaffMind").get("v.value"));
			cmp.set("v.visitationPlanDetail.ASI_MY_CRM_Familiar_WITH_PRM__c",cmp.find("familiarWithPRM").get("v.value"));
			cmp.set("v.visitationPlanDetail.ASI_MY_CRM_Recommend__c",cmp.find("Recommend").get("v.value"));
			cmp.set("v.visitationPlanDetail.ASI_MY_CRM_Not_Recommend_Reason__c",cmp.find("NotRecommendReason").get("v.value"));
			cmp.set("v.visitationPlanDetail.ASI_MY_CRM_Incentive__c",cmp.find("Incentive").get("v.value"));
			console.log(cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Top_Of_Staff_Mind__c"));
			console.log(cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Familiar_WITH_PRM__c"));
			console.log(cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Recommend__c"));
			console.log(cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Not_Recommend_Reason__c"));
			console.log(cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Incentive__c"));
		}
		cmp.set("v.isChanged",true);
		console.log(cmp.get("v.isChanged"));
	},

	changeSection : function(cmp,event, helper) {
		document.getElementById('Q').style.backgroundColor = 'white';
		document.getElementById('Q').style.color = 'black';
		document.getElementById('V').style.backgroundColor = 'white';
		document.getElementById('V').style.color = 'black';
		document.getElementById('A').style.backgroundColor = 'white';
		document.getElementById('A').style.color = 'black';
		document.getElementById('P').style.backgroundColor = 'white';
		document.getElementById('P').style.color = 'black';
		document.getElementById(event.target.id).style.backgroundColor = '#033466';
		document.getElementById(event.target.id).style.color = 'white';

		cmp.set("v.section",event.target.id);

		if(cmp.get("v.section")=='Q')
		{
			cmp.find("BottleLabel").set("v.value",cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Bottle_Label__c"));
			cmp.find("CustodyCondition").set("v.value",cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Custody_Condition__c"));
		}
		if(cmp.get("v.section")=='V')
		{
			cmp.find("OutletType").set("v.value",cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Outlet_Type__c"));
			cmp.find("FollowPlan").set("v.value",cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Follow_Plan__c"));
			cmp.find("BarDisplay").set("v.value",cmp.get("v.visitationPlanDetail.ASI_CRM_MY_BarDisplay__c"));
			cmp.find("Planogram").set("v.value",cmp.get("v.visitationPlanDetail.ASI_CRM_MY_Planogram__c"));
			cmp.find("Improvements").set("v.value",cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Improvements__c"));
		}
		if(cmp.get("v.section")=='A')
		{
			cmp.find("ownActivations").set("v.value",cmp.get("v.visitationPlanDetail.ASI_CRM_MY_Own_Activations__c"));
			cmp.find("OwnActivationBrandNameRemarks").set("v.value",cmp.get("v.visitationPlanDetail.ASI_CRM_MY_OwnActivationRemark__c"));
		}
		if(cmp.get("v.section")=='P')
		{
			cmp.find("topOfStaffMind").set("v.value",cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Top_Of_Staff_Mind__c"));
			cmp.find("familiarWithPRM").set("v.value",cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Familiar_WITH_PRM__c"));
			cmp.find("Recommend").set("v.value",cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Recommend__c"));
			cmp.find("NotRecommendReason").set("v.value",cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Not_Recommend_Reason__c"));
			cmp.find("Incentive").set("v.value",cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Incentive__c"));
		}
	},

	updateVisitationDetail : function(cmp,event,helper) {
		
			swal.fire({
				title: 'Save QVAP',
				text: "Are you sure?",
				showCancelButton: true,
				confirmButtonColor: '#3085d6',
				cancelButtonColor: '#d33',
				confirmButtonText: 'Confirm'
			}).then((result) => {
				if(result.value) {
					helper.updateVisitationDetail(cmp,cmp.get("v.visitationPlanDetail"));
					cmp.set("v.isChanged",false);
					$A.util.removeClass(cmp.find("customSpinner"), 'slds-hide');
				}
			});
	},

	backToVisitationDetail : function(cmp, event, helper) {
        var nav = cmp.find("navService");
		var id = cmp.get("v.recordId");
		var pageReference = {
			type: 'standard__component',
			attributes: {
				componentName: 'c__ASI_CRM_VisitationPlanToday'
			}, 
			state: {
				c__id: id,
			}
		};

        nav.navigate(pageReference);
    }


})