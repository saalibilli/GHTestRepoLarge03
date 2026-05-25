import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import getRecords from '@salesforce/apex/ServiceController.getRecords';
import processRecords from '@salesforce/apex/ServiceController.processRecords';
import ID_FIELD from '@salesforce/schema/Account.Id';
import NAME_FIELD from '@salesforce/schema/Account.Name';

const COLUMNS = [
    { label: 'Name', fieldName: 'name', type: 'text', sortable: true },
    { label: 'Amount', fieldName: 'amount', type: 'currency', sortable: true },
    { label: 'Status', fieldName: 'status', type: 'text', sortable: true },
    { label: 'Created', fieldName: 'createdDate', type: 'date', sortable: true },
    {
        type: 'action',
        typeAttributes: { rowActions: [
            { label: 'View', name: 'view' },
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ]}
    }
];

const PAGE_SIZE = 25;

export default class dataManager22 extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api title = "Record Manager";
    @api pageSize = 25;
    @track records = [];
    @track filteredRecords = [];
    @track selectedRows = [];
    @track isLoading = true;
    @track error;
    @track currentPage = 1;
    @track totalPages = 1;
    @track sortedBy;
    @track sortDirection = 'asc';
    @track searchTerm = '';
    @track filterStatus = 'all';
    @track showModal = false;
    @track modalRecord = {};

    columns = COLUMNS;
    wiredResult;

    get pageInfo() {
        const start = (this.currentPage - 1) * PAGE_SIZE + 1;
        const end = Math.min(this.currentPage * PAGE_SIZE, this.filteredRecords.length);
        return `Showing ${start}-${end} of ${this.filteredRecords.length} records`;
    }

    get isFirstPage() { return this.currentPage <= 1; }
    get isLastPage() { return this.currentPage >= this.totalPages; }
    get hasRecords() { return this.filteredRecords.length > 0; }
    get statusOptions() {
        return [
            { label: 'All', value: 'all' },
            { label: 'Active', value: 'Active' },
            { label: 'Inactive', value: 'Inactive' },
            { label: 'Pending', value: 'Pending' }
        ];
    }

    @wire(getRecords, { recordId: '$recordId', pageSize: PAGE_SIZE })
    wiredGetRecords(result) {
        this.wiredResult = result;
        this.isLoading = true;
        if (result.data) {
            this.records = result.data.map(r => ({
                ...r,
                cssClass: r.status === 'Active' ? 'slds-text-color_success' : 'slds-text-color_weak'
            }));
            this.applyFilters();
            this.error = undefined;
        } else if (result.error) {
            this.error = this.reduceErrors(result.error);
            this.records = [];
        }
        this.isLoading = false;
    }

    connectedCallback() {
        this.loadPreferences();
    }

    renderedCallback() {
        if (this.hasRecords) {
            this.highlightSelectedRows();
        }
    }

    handleSearch(event) {
        this.searchTerm = event.target.value.toLowerCase();
        this.currentPage = 1;
        this.applyFilters();
    }

    handleFilterChange(event) {
        this.filterStatus = event.detail.value;
        this.currentPage = 1;
        this.applyFilters();
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.applyFilters();
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'view':
                this.navigateToRecord(row.id);
                break;
            case 'edit':
                this.openEditModal(row);
                break;
            case 'delete':
                this.handleDelete(row.id);
                break;
        }
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    handlePrevious() {
        if (this.currentPage > 1) this.currentPage--;
    }

    handleNext() {
        if (this.currentPage < this.totalPages) this.currentPage++;
    }

    async handleBulkProcess() {
        if (this.selectedRows.length === 0) {
            this.showToast('Warning', 'Please select records to process', 'warning');
            return;
        }
        this.isLoading = true;
        try {
            const ids = this.selectedRows.map(r => r.id);
            await processRecords({ recordIds: ids });
            this.showToast('Success', `Processed ${ids.length} records`, 'success');
            await refreshApex(this.wiredResult);
        } catch (error) {
            this.showToast('Error', this.reduceErrors(error), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    openEditModal(record) {
        this.modalRecord = { ...record };
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
        this.modalRecord = {};
    }

    async handleModalSave() {
        this.isLoading = true;
        try {
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.modalRecord.id;
            fields[NAME_FIELD.fieldApiName] = this.modalRecord.name;
            await updateRecord({ fields });
            this.showToast('Success', 'Record updated', 'success');
            this.closeModal();
            await refreshApex(this.wiredResult);
        } catch (error) {
            this.showToast('Error', this.reduceErrors(error), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    applyFilters() {
        let results = [...this.records];
        if (this.searchTerm) {
            results = results.filter(r =>
                r.name && r.name.toLowerCase().includes(this.searchTerm)
            );
        }
        if (this.filterStatus !== 'all') {
            results = results.filter(r => r.status === this.filterStatus);
        }
        if (this.sortedBy) {
            results.sort((a, b) => {
                let valA = a[this.sortedBy] || '';
                let valB = b[this.sortedBy] || '';
                if (typeof valA === 'string') valA = valA.toLowerCase();
                if (typeof valB === 'string') valB = valB.toLowerCase();
                let comparison = valA < valB ? -1 : valA > valB ? 1 : 0;
                return this.sortDirection === 'asc' ? comparison : -comparison;
            });
        }
        this.filteredRecords = results;
        this.totalPages = Math.ceil(results.length / PAGE_SIZE) || 1;
    }

    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId, objectApiName: this.objectApiName, actionName: 'view' }
        });
    }

    handleDelete(recordId) {
        // Implementation would use deleteRecord from uiRecordApi
        this.showToast('Info', 'Delete not implemented in demo', 'info');
    }

    loadPreferences() {
        const saved = localStorage.getItem('dataManager22_prefs');
        if (saved) {
            const prefs = JSON.parse(saved);
            this.sortedBy = prefs.sortedBy;
            this.sortDirection = prefs.sortDirection;
            this.filterStatus = prefs.filterStatus || 'all';
        }
    }

    highlightSelectedRows() {
        // DOM manipulation for visual feedback
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    reduceErrors(errors) {
        if (!Array.isArray(errors)) errors = [errors];
        return errors
            .filter(e => !!e)
            .map(e => e.body?.message || e.message || JSON.stringify(e))
            .join(', ');
    }
}
