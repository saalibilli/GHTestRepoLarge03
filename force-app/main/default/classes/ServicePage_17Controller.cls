public with sharing class ServicePage_17Controller {
    public List<Account> records { get; set; }
    public String searchTerm { get; set; }
    public String selectedStatus { get; set; }
    public String selectedRecordId { get; set; }

    public ServicePage_17Controller() {
        records = [SELECT Id, Name, CreatedDate FROM Account LIMIT 100];
    }

    public List<SelectOption> getStatusOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'All'));
        options.add(new SelectOption('Active', 'Active'));
        options.add(new SelectOption('Inactive', 'Inactive'));
        return options;
    }

    public PageReference refresh() {
        records = [SELECT Id, Name, CreatedDate FROM Account LIMIT 100];
        return null;
    }

    public PageReference save() {
        return null;
    }

    public PageReference applyFilters() {
        return null;
    }

    public PageReference editRecord() {
        return null;
    }

    public PageReference deleteRecord() {
        return null;
    }
}
