/**
 * @author: PZ - CustomerTimes Corp.
 * @date: 10.01.18
 */
({
    loadValues : function (component) {
        var record = component.get("v.record");
        var subheading = '';
        for(var i=0; i<component.get("v.subHeadingFieldsAPI").length ;i++ ){
            if(record[component.get("v.subHeadingFieldsAPI")[i]]){
                subheading = subheading + record[component.get("v.subHeadingFieldsAPI")[i]] + ' • ';
            }
        }
        subheading = subheading.substring(0,subheading.lastIndexOf('•'));
        component.set("v.subHeadingFieldValues", subheading);
    },

    choose : function (component,event) {
        var chooseEvent = component.getEvent("lookupSelect");
        chooseEvent.setParams({
            "recordId" : component.get("v.record").Id,
            "recordLabel":component.get("v.record").Name
        });
        chooseEvent.fire();
        
    }
})