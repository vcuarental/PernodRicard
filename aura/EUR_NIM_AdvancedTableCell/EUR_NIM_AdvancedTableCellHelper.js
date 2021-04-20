/**
 * Created by thomas.schnocklake on 06.04.18.
 */
({
    extract: function(object, fieldName)
    {
        if (typeof object[fieldName] !== "undefined")
        {
            return object[fieldName]
        }
        var val = object;
        fieldName.split('.').forEach(function(part)
        {
            if (typeof val === "undefined" || val === null)
            {
                val = {};
            }
            val = val[part];
        });
        return val;
    },
})