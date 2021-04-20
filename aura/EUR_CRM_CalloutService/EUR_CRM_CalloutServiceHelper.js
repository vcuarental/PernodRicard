({
    runApex : function (cmp, name, params, flags) {
        var ctx = cmp.get('v.context');
        var action = ctx.get('c.' + name);
        // console.log('Callout Service action : ' , JSON.stringify(action));
        // console.log('Callout Service action : ' , action);
        // console.log('Callout Service ctx : ' , ctx);
        // console.log('Callout Service cmp : ' , cmp);
        // console.log('Callout Service params : ' , JSON.stringify(params));
        // console.log('Callout Service flags : ' , JSON.stringify(flags));

        if (!$A.util.isEmpty(params) && typeof(params) === 'object') {
            action.setParams(params);
        } else if (typeof(params) !== 'object') {
            throw 'Apex method params must be an object';
        }
        return new Promise((resolve, reject) => {
            action.setCallback(this, function(response) {
                // console.log('setCAllback');
                // console.log('ctx.isValid() ' , ctx.isValid());
                var state = response.getState();
                // console.log('state ' , state);
                if (ctx.isValid() && state === 'SUCCESS') {
                    var returnValue = response.getReturnValue();
                    // console.log('response.getReturnValue ' , JSON.stringify(returnValue))
                    resolve(returnValue);
                } else if (ctx.isValid() && state === 'INCOMPLETE') {
                    reject(response);
                } else if (ctx.isValid() && state === 'ERROR') {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            reject(Error('Error message: ' + errors[0].message));
                        }
                    } else {
                        reject(Error('Unknown error'));
                    }
                }
            });
            if (!$A.util.isEmpty(flags)) {
                try {
                    flags.forEach(f => {
                        if (typeof(action[f]) === 'function') {
                            action[f]()
                        }
                    });
                } catch(e) {
                    console.error(e);
                }

            }
            $A.enqueueAction(action);
        });
    },

    createComponent : function (cmp, type, params) {
        var newPromise = new Promise((resolve, reject) => {
            $A.createComponent(type, params, function(newCmp, status, errorMessage) {
                if (cmp.get('v.context').isValid() && status === 'SUCCESS') {
                    resolve(newCmp);
                } else {
                    reject(errorMessage);
                }
            });
        });
        // console.log('newPromise ' , newPromise);
        return newPromise;
    },

    createComponents : function (cmp, components) {
        return new Promise((resolve, reject) => {
            $A.createComponents(components, function(newComponents, status, errorMessage) {
                if (cmp.get('v.context').isValid() && status === 'SUCCESS') {
                    resolve(newComponents);
                } else {
                    reject(errorMessage);
                }
            });
        });
    },

    getComponentsBuilder : function (cmp, helper) {
        class ComponentsBuilder {
            constructor() {
                this._components = [];
            }

            append(type, params) {
                this._components.push([type, params]);
                return this;
            }

            build() {
                return helper.createComponents(cmp, this._components);
            }
        }
        return new ComponentsBuilder();
    }
});