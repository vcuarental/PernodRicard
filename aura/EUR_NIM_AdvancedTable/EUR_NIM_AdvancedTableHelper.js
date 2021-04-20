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
    handleListOrColsChange : function (component, event, helper) {
        helper.recreateGroups(component, event, helper);
    },
    recreateGroups : function (component, event, helper) {
        var columns = component.get('v.columns');
        var objectList = component.get('v.objectList');

        var sortField = component.get('v.sortField');
        var groupField = component.get('v.groupField');
        var sortDir = component.get('v.sortDir');
        var sortMod = sortDir == 'asc' ? 1 : -1;

        var groupExpansion = component.get('v.groupExpansion');

        var groupList = [];
        if (!columns || !objectList)
            return;

        const map1 = objectList.map(x => x[groupField]);

        var groupMap = new Map();

        objectList.forEach(
            function(rowObject) {
                var groupKey = groupField ? helper.extract(rowObject, groupField) : '';
                var group = groupMap.get(groupKey);
                if (!group)
                {
                    group = {
                        isGroup: true,
                        entries:[],
                        key: groupKey,
                        showDetails: !(groupExpansion === 'forceClosed' || groupExpansion === 'defaultClosed')
                    };
                    groupMap.set(groupKey,group);
                }
                group.entries.push(rowObject);
            }
        );

        function aggregate(entryObjects, aggregateObject)
        {
            entryObjects.forEach(function(entryObject) {
                aggregateObject.count = (aggregateObject.count || 0 ) + 1
                columns.forEach(
                    function(col)
                    {
                        var extractedVal = helper.extract(entryObject,col.fieldName);

                        if (true)
                        {
                            if (col.groupFunction === 'SUM' || col.groupFunction === 'AVG')
                            {
                                var count = aggregateObject[col.fieldName] || 0;
                                var value = isNaN(extractedVal) ? 0 : extractedVal;
                                aggregateObject[col.fieldName] = Number.parseFloat(count) +  Number.parseFloat(value);
                                
                                if (col.currencyFieldName)
                                {
                                    aggregateObject[col.currencyFieldName] = helper.extract(entryObject,col.currencyFieldName);
                                }
                            } 
                            if (col.groupFunction === 'LAST')
                            {
                                aggregateObject[col.fieldName] = extractedVal;

                                if ( col.linkFieldName && !aggregateObject["linkFieldName"] ) {
                                    aggregateObject["linkFieldName"] = col.linkFieldName;
                                    aggregateObject[col.linkFieldName] = helper.extract(entryObject, col.linkFieldName);
                                }
                            }
                        }
                    }
                );

            });
        }
        function aggregateFinish(aggregateObject, isTotalRow)
        {
            columns.forEach(
                function(col)
                {
                    if (col.groupFunction === 'AVG')
                    {
                        aggregateObject[col.fieldName] = aggregateObject[col.fieldName] / aggregateObject.count;
                    }
                    if (col.groupFunction === 'LAST' && isTotalRow)
                    {
                        aggregateObject[col.fieldName] = null;
                        aggregateObject[col.linkFieldName] = null;
                    }
                }
            );

        }
        var totalObj = {};

        groupMap.forEach(function(group,groupKey) {
            group.value = {};

            aggregate(group.entries,group.value);
            aggregate(group.entries,totalObj);
            aggregateFinish(group.value, false);

            groupList.push(group);
        });
        aggregateFinish(totalObj, true);

        component.set('v.totalObj', totalObj);
        component.set('v.groupList', groupList);
    },
    attachDND : function (component, event, helper) {
/*        setTimeout(function(e){

            $('.ddrag').draggable({
              helper: "clone",
              iframeFix: true,
                zIndex: 999,
              cursor: "move",
              cursorAt: { top: -12, left: -20 },
              helper: function( event )
              {
                  console.log(event);
                  var name = $(event.target).data().name
                return $( "<div class='ui-widget-header'>" + name + "</div>" );
              }
            });
        }, 100);
*/
    },
    applyPagination : function (component, event, helper)
    {
        var groupList = component.get('v.groupList');
        var groupField = component.get('v.groupField');

        var fromIndex = component.get('v.fromIndex');
        var pageSize = component.get('v.pageSize') ;
        var toIndex = fromIndex + pageSize -1;
        var groupListVisible = [];

        var rowIndex = 0;
        var visibleRows = [];

        groupList.forEach(function(group)
        {
            if (groupField) // show group at all
            {

                if (fromIndex <= rowIndex && visibleRows.length < pageSize)
                {
                    visibleRows.push(group);
                }
                rowIndex++;
            }
            group.entries.forEach(function(groupEntry)
            {
                if (group.showDetails)
                {
                    if (fromIndex <= rowIndex && visibleRows.length < pageSize)
                    {
                        visibleRows.push(groupEntry);
                    }
                    rowIndex++;
                }
            });
        });
        component.set('v.visibleRows', visibleRows);
    },
    applySorting : function (component, event, helper) {
        var columns = component.get('v.columns');
        var groupList = component.get('v.groupList');
        var sortField = component.get('v.sortField');
        var groupField = component.get('v.groupField');
        var sortDir = component.get('v.sortDir');
        var sortMod = sortDir == 'ASC' ? 1 : -1;


        var sortCol = columns.find(col => col.fieldName === sortField );

        var sortFunc = function(a,b)
        {
            var a1 = helper.extract(a,sortField);
            var b1 = helper.extract(b,sortField);
            return sortMod * (a1 < b1 ? -1 : a1 > b1 ? 1 : 0);
        };

        if (sortCol && (sortCol.type === 'STRING' || sortCol.type === 'REFERENCE') )
        {
            sortFunc = function(a,b)
            {
                var a1 = helper.extract(a,sortField) || '';
                var b1 = helper.extract(b,sortField) || '';

                return sortMod * (a1 < b1 ? -1 : a1 > b1 ? 1 : 0);
            };
        }
        if (sortCol && (sortCol.type === 'DATETIME' || sortCol.type === 'DATE'))
        {
            sortFunc = function(a,b)
            {
                var a1 = typeof helper.extract(a,sortField) === "undefined" ? null : new Date(helper.extract(a,sortField));
                var b1 = typeof helper.extract(b,sortField) === "undefined" ? null : new Date(helper.extract(b,sortField));

                return sortMod * (a1 < b1 ? -1 : a1 > b1 ? 1 : 0);
            };
        }
        if (sortCol && (sortCol.type === 'DOUBLE' || sortCol.type === 'CURRENCY') )
        {
            sortFunc = function(a,b)
            {
                var a1 = helper.extract(a,sortField) || 0;
                var b1 = helper.extract(b,sortField) || 0;
                return sortMod * (a1 < b1 ? -1 : a1 > b1 ? 1 : 0);
            };
        }
        groupList.sort(function(a,b){
            return sortFunc(a.value,b.value);
        });

        groupList.forEach(function(group)
        {
            group.entries.sort(sortFunc);
        });

    },

})