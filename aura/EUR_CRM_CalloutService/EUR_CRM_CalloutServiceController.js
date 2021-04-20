({
    /**
     * Construct Promise with Apex controller's @AuraEnabled method invocation.
     * Typical usage:
     *
     *  calloutService.runApex(apexMethodName, params)
     *      .then(result => {
     *          //process result
     *      })
     *      .catch(error => {
     *          //handle errors
     *      });
     *
     * @param cmp
     * @param event
     * @param helper
     * @returns {*} Promise of $A.enqueueAction() calling
     */
    runApex : function (cmp, event, helper) {
        var args = event.getParam('arguments');
        return helper.runApex(cmp, args.name, args.params, args.flags);
    },

    /**
     * Construct Promise with callout to create new instance of Aura component.
     * Typical usage:
     *
     *  calloutService.createComponent(newCmpType, params)
     *      .then(result => {
     *          //process result
     *      })
     *      .catch(error => {
     *          //handle errors
     *      });
     *
     * @param cmp
     * @param event
     * @param helper
     * @returns {*} Promise of $A.createComponent() calling
     */
    createComponent : function (cmp, event, helper) {
        var args = event.getParam('arguments');
        // console.log('args.type : ' , JSON.stringify(args.type));
        // console.log('args.params : ' , args.params);
        return helper.createComponent(cmp, args.type, args.params);
    },

    /**
     * Construct Promise with callout to create a plenty of instances of Aura components in single transaction.
     * Typical usage:
     *
     *  calloutService.createComponents([[cmpType1, params1],[cmpType2, params2],...,[cmpTypeN, paramsN]])
     *      .then(results => {
     *          //process results - array of new components
     *      }})
     *      .catch(error => {
     *          //handle errors
     *      });
     *
     * @param cmp
     * @param event
     * @param helper
     * @returns {*} Promise of $A.createComponent() calling
     */
    createComponents : function (cmp, event, helper) {
        var args = event.getParam('arguments');
        return helper.createComponents(cmp, args.components);
    },

    /**
     * Construct builder to create multiple Aura components in a single transaction
     * Typical usage:
     *
     *  calloutService.getComponentsBuilder()
     *      .append(newCmpType1, params1)
     *      .append(newCmpType2, params2)
     *          ...
     *      .append(newCmpTypeN, paramsN)
     *      .build()
     *      .then(results => {
     *          //process results - array of new components
     *      })
     *      .catch(error => {
     *          //handle errors
     *      });
     *
     * @param cmp
     * @param event
     * @param helper
     * @returns {*}
     */
    getComponentsBuilder : function (cmp, event, helper) {
        return helper.getComponentsBuilder(cmp, helper);
    }
});