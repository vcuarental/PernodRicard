/**
 * Created by bsavcı on 8/27/2020.
 */

({
    afterRender: function (component, helper) {
        this.superAfterRender();
        helper.reloadData(component);
    }
});