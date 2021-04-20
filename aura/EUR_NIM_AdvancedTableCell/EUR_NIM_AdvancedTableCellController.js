/**
 * Created by thomas.schnocklake on 06.04.18.
 */
({
    init: function (component, event, helper) {
        var object = component.get('v.object');
        var col = component.get('v.column');
        if (object)
        {
            var value = col && col.fieldName ? helper.extract(object,col.fieldName) : null;

            if (col.type == "DATETIME") {
                console.log("DATETIME");
                console.log(value)
            }

            component.set('v.value', value);

            if (col.linkFieldName)
            {
                var link = helper.extract(object,col.linkFieldName);
                if (link)
                {
                    var relativeLink = "/" + link;
                    component.set('v.link', relativeLink);
                }
            }

            component.set('v.isLinkValid', typeof col.linkFieldName != "undefined" );

            if (typeof col.currencyFieldName !== "undefined" && col.currencyFieldName)
            {
                var currency = helper.extract(object,col.currencyFieldName);
                if (currency)
                    component.set('v.currencyISO', currency);
            }
        }
    },
})