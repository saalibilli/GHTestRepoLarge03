({
    doInit: function(component, event, helper) {
        helper.initColumns(component);
        helper.loadRecords(component);
    },

    handleRecordChange: function(component, event, helper) {
        helper.loadRecords(component);
    },

    handleRefresh: function(component, event, helper) {
        helper.loadRecords(component);
    },

    handleNew: function(component, event, helper) {
        var createEvent = $A.get("e.force:createRecord");
        createEvent.setParams({ entityApiName: "Account" });
        createEvent.fire();
    },

    handleRowAction: function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'view':
                helper.navigateToRecord(component, row.Id);
                break;
            case 'edit':
                helper.editRecord(component, row.Id);
                break;
            case 'delete':
                component.set('v.showConfirmation', true);
                component.set('v.selectedIds', [row.Id]);
                break;
        }
    },

    handleSelection: function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        var ids = selectedRows.map(function(row) { return row.Id; });
        component.set('v.selectedIds', ids);
    },

    handlePrev: function(component, event, helper) {
        var page = component.get('v.currentPage');
        if (page > 1) {
            component.set('v.currentPage', page - 1);
            helper.loadRecords(component);
        }
    },

    handleNext: function(component, event, helper) {
        var page = component.get('v.currentPage');
        component.set('v.currentPage', page + 1);
        helper.loadRecords(component);
    },

    closeConfirmation: function(component) {
        component.set('v.showConfirmation', false);
    },

    confirmAction: function(component, event, helper) {
        component.set('v.showConfirmation', false);
        helper.deleteRecords(component, component.get('v.selectedIds'));
    }
})
