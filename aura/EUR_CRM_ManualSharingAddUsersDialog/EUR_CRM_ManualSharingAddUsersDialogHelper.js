/**
 * Created by V. Kamenskyi on 27.09.2017.
 */
({
    setDefaults : function (cmp, helper) {
        cmp.set('v.searchSubject', 'groups');
        cmp.find('searchSubject').set('v.value', 'groups');
        cmp.set('v.result', []);
        cmp.find('duelingPicklist').set('v.itemsL', cmp.get('v.groups'));
        cmp.set('v.accessLevel', 'read');
        cmp.set('v.reason', ($A.util.isEmpty(cmp.get('v.reasons')) ? [{value:'Manual'}] : cmp.get('v.reasons'))[0].value);
    },

    selectUserOrGroup : function (cmp, helper, who) {
        cmp.set('v.searchSubject', who);
        var right = cmp.get('v.result') || [];
        cmp.find('duelingPicklist').set('v.itemsL', cmp.get('v.' + who).filter(record => !right.some(item => item.name == record.name)));
    },

    search : function (cmp, helper, word) {
        var items = cmp.get('v.' + cmp.get('v.searchSubject'));
        var right = cmp.find('duelingPicklist').get('v.itemsR');
        var left = items.filter(item => !right.some(r => r.name === item.name));
        if (!$A.util.isEmpty(left)) {
            cmp.find('duelingPicklist').set('v.itemsL', word
                    ? left.filter(item => (item.label || '').toLowerCase().includes(word.trim().toLowerCase()))
                    : left
            );
        }
    },
    
    filerApexDelayed : function (cmp, event) {
        var sEvt = cmp.getEvent('searchEvent');
		sEvt.fire();        
    }
})