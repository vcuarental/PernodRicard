/**
 * Created by V. Kamenskyi on 18.09.2017.
 */
({
    handleSelection : function (cmp, event, helper) {
        var sel = helper.getSelectionInstance(cmp, event);
        if (event.ctrlKey) {
            sel.toggleSingle();
        } else if (event.shiftKey) {
            sel.toggleRange();
        } else {
            sel.toggleAll();
        }

    },

    getSelectionInstance : function (cmp, event) {
        class Selection {
            toggleAll() {
                var items = cmp.get('v.items');
                var pos = event.target.dataset.pos;
                for (let i = 0; i < items.length; i++) {
                    items[i].selected = false;
                }
                items[pos].selected = true;
                cmp.set('v.items', items);
            }

            toggleSingle() {
                var items = cmp.get('v.items');
                var pos = event.target.dataset.pos;
                items[pos].selected = !items[pos].selected;
                cmp.set('v.items', items);
            }

            toggleRange() {
                var items = cmp.get('v.items');
                var pos = event.target.dataset.pos;
                for (let i = 0; i < items.length; i++) {
                    if (items[i].selected && i < pos) {
                        for (let k = i; k <= pos; k++) {
                            items[k].selected = true;
                        }
                        this.clearRange(pos, items.length, items);
                        break;
                    } else if (items[i].selected && i > pos) {
                        for (let k = i; k > pos; k--) {
                            items[k].selected = true;
                        }
                        this.clearRange(i, items.length, items);
                        break;
                    } else if (i != pos) {
                        items[i].selected = false;
                    }
                }
                items[pos].selected = true;
                cmp.set('v.items', items);
            }

            clearRange(left, right, items) {
                if (left < right) {
                    for (let k = left + 1; k < right; k++) {
                        items[k].selected = false;
                    }
                }
            }
        }
        return new Selection();
    }
})