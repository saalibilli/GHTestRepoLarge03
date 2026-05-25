({
    initColumns: function(component) {
        component.set('v.columns', [
            { label: 'Name', fieldName: 'Name', type: 'text', sortable: true },
            { label: 'Industry', fieldName: 'Industry', type: 'text' },
            { label: 'Revenue', fieldName: 'AnnualRevenue', type: 'currency' },
            { label: 'City', fieldName: 'BillingCity', type: 'text' },
            { type: 'action', typeAttributes: { rowActions: [
                { label: 'View', name: 'view' },
                { label: 'Edit', name: 'edit' },
                { label: 'Delete', name: 'delete' }
            ]}}
        ]);
    },

    loadRecords: function(component) {
        component.set('v.isLoading', true);
        var action = component.get('c.getRecords');
        action.setParams({
            recordId: component.get('v.recordId'),
            pageNumber: component.get('v.currentPage'),
            sortField: component.get('v.sortField'),
            sortOrder: component.get('v.sortOrder')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.records', result.records);
                component.set('v.totalCount', result.totalCount);
                component.set('v.error', null);
            } else {
                var errors = response.getError();
                var message = 'Unknown error';
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                component.set('v.error', message);
            }
            component.set('v.isLoading', false);
        });

        $A.enqueueAction(action);
    },

    navigateToRecord: function(component, recordId) {
        var navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({ recordId: recordId });
        navEvent.fire();
    },

    editRecord: function(component, recordId) {
        var editEvent = $A.get("e.force:editRecord");
        editEvent.setParams({ recordId: recordId });
        editEvent.fire();
    },

    deleteRecords: function(component, ids) {
        component.set('v.isLoading', true);
        var action = component.get('c.deleteRecords');
        action.setParams({ recordIds: ids });
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                this.showToast('Success', 'Records deleted', 'success');
                this.loadRecords(component);
            } else {
                this.showToast('Error', 'Failed to delete records', 'error');
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    showToast: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({ title: title, message: message, type: type });
        toastEvent.fire();
    }
})
