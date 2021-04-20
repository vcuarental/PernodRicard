/**
 * Created by V. Kamenskyi on 27.02.2018.
 */
({
    /**
     * Describes the DialogBuilder type
     *
     * @param cmp
     * @param helper
     * @returns {{new(): DialogBuilder}}
     */
    getClass : function (cmp, helper) {

        /**
         * Returns Lightning reference object if plain function was provided
         *
         * @param name
         * @param callback
         * @returns {*}  decorated callback function
         */
        function getCallbackReference(name, callback) {
            if (typeof callback === 'function') {
                cmp.set('v._actionsStorage.' + name, callback);
                return cmp.getReference('c._dispatchCallback');
            }
            return callback;
        }

        return class DialogBuilder {
            constructor() {
                this._defaultActions = {
                    'reject' : [],
                    'submit' : []
                };
                this._extraActions = [];
                cmp.set('v._actionsStorage', Object.defineProperty({}, '__default__', {
                    enumerable: false,
                    configurable: false,
                    writable: false,
                    value: 'static'
                }));
            }
            submitAction(label, callback, properties) {
                this._defaultActions.submit = [['lightning:button', {
                    'name' : 'submit',
                    'label' : label || 'Okay',
                    'variant' : 'brand',
                    'disabled' : properties && properties.disabled,
                    'onclick' : getCallbackReference('submit', callback)
                }]];
                return this;
            }
            rejectAction(label, callback) {
                this._closeCallback = callback;
                callback._isReject = true;
                this._defaultActions.reject = [['lightning:button', {
                    'name' : 'reject',
                    'label' : label || 'Cancel',
                    'onclick' : getCallbackReference('reject', callback)
                }]];
                return this;
            }
            extraAction(name, label, callback, cssClass, variant, iconName, iconPosition) {
                this._extraActions.push(
                    ['lightning:button', {
                        'name' : name,
                        'label' : label,
                        'variant' : variant || 'neutral',
                        'class' : cssClass,
                        'onclick' : getCallbackReference(name, callback),
                        'iconName' : iconName,
                        'iconPosition' : iconPosition || 'left'
                    }]
                );
                return this;
            }
            header(label) {
                this._headerLabel = label;
                return this;
            }
            body(content) {
                this._bodyContent = content;
                return this;
            }
            cssClass(cssClass) {
                this._cssClass = cssClass;
                return this;
            }
            build() {
                const _self = this;
                this.showModal = function () {
                    helper.CalloutService
                        .createComponents(this._extraActions
                            .concat(this._defaultActions.reject)
                            .concat(this._defaultActions.submit)
                        ).then(result => {
                        helper.OverlayService.showCustomModal({
                            'header' : this._headerLabel,
                            'body' : this._bodyContent,
                            'footer' : result,
                            'showCloseButton' : true,
                            'cssClass' : this._cssClass,
                            'closeCallback' : function(){
                                if (_self._closeCallback && !helper._dialogActionContext) {
                                    _self._closeCallback()
                                } else {
                                    helper._dialogActionContext = '';
                                }
                            }
                        }).then(overlay => {
                            overlay['content'] = this._bodyContent;
                            cmp.set('v._overlayPanel', overlay);
                        }).catch(overlayError => {
                            console.error('User dialog mode exception:', overlayError);
                        });
                    }).catch(error => {
                        console.error(error);
                    });
                }
                return this;
            }
        }
    },


    /**
     * Close modal dialog
     *
     * @param context
     */
    closePopup : function (cmp, context) {
        this._dialogActionContext = context;
        this.OverlayService.notifyClose()
            .then(result => {
                cmp.get('v._overlayPanel')[0].close();
            }).catch(error => {
            console.log('... close popup error ...', error);
        });
    }
})