/**
 * Created by V. Kamenskyi on 12.09.2017.
 */
({
    init : function (cmp, helper) {
        helper.setDefaults(cmp, helper);
    },

    setDefaults : function (cmp, helper) {
        cmp.set('v.compareFunctions', {
            'left' : helper.getComparator(cmp.get('v.sortOrderL')),
            'right' : helper.getComparator(cmp.get('v.sortOrderR'))
        });
    },

    reorder : function (cmp, helper, direction) {
        var items = cmp.get('v.itemsR') || [];
        if (!$A.util.isEmpty(items)) {
            switch (direction) {
                case 'up' :
                    let start = items.findIndex(item => item.selected);
                    if (start && start > 0) {
                        let tmp;
                        for (let pos = start; pos < items.length; pos++) {
                            if (items[pos].selected) {
                                tmp = items[pos - 1]
                                items[pos - 1] = items[pos];
                                items[pos] = tmp;
                            }
                        }
                        cmp.set('v.itemsR', items);
                    }
                    break;
                case 'down' :
                    let end = items.findIndex(item => item.selected);
                    for (let i = items.length - 1; i >= 0; i--) {
                        if (items[i].selected) {
                            end = i;
                            break;
                        }
                    }
                    if (end && end < items.length - 1) {
                        let tmp;
                        for (let pos = end; pos >= 0; pos--) {
                            if (items[pos].selected) {
                                tmp = items[pos + 1]
                                items[pos + 1] = items[pos];
                                items[pos] = tmp;
                            }
                        }
                        cmp.set('v.itemsR', items);
                    }
                    break;
            }
        }
    },

    move : function (cmp, helper, direction) {
        var items = cmp.get('v.items' + (direction == 'right' ? 'L' : 'R')) || [];
        if (items.length > 0) {
            let selected = items.filter(item => item.selected) || [];
            if (selected.length > 0) {
                let settled = items.filter(item => !item.selected) || [];
                let compare = cmp.get('v.compareFunctions') || {};
                let result = cmp.get('v.items' + (direction == 'left' ? 'L' : 'R')).concat(selected);
                if (compare[direction]) result.sort(compare[direction]);
                cmp.set('v.itemsL', []);
                cmp.set('v.itemsR', []);
                cmp.set('v.itemsL', (direction == 'right' ? settled : result));
                cmp.set('v.itemsR', (direction == 'left' ? settled : result));
            }
        }
        if (direction == 'left') {
            cmp.getEvent('onMoveLeft').fire();
        }
    },

    getComparator : function (order) {
        if (!order) return null;
        switch(order.toLowerCase()) {
            case 'asc' :
                return function (a, b) {
                    if (a.label.toLowerCase() > b.label.toLowerCase()) return 1;
                    if (a.label.toLowerCase() < b.label.toLowerCase()) return -1;
                    return 0;
                };
            case 'desc' :
                return function (a, b) {
                    if (a.label.toLowerCase() > b.label.toLowerCase()) return -1;
                    if (a.label.toLowerCase() < b.label.toLowerCase()) return 1;
                    return 0;
                };
        }
    }
})