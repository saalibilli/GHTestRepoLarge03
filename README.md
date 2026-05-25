# LargeSFDXProject

A large, realistic SFDX project designed for **performance testing** of Salesforce CLI tooling, IDE extensions, CI/CD pipelines, and source-tracking operations.

## Purpose

This project provides a substantial metadata corpus to stress-test:

- `sf project deploy start` / `sf project retrieve start` performance
- Source tracking and conflict detection at scale
- IDE indexing and IntelliSense (VS Code, JetBrains)
- Static analysis and scanning tools
- CI/CD pipeline throughput

## Project Stats

| Metric | Value |
|--------|-------|
| Total components | 3,617 |
| Total files | ~6,100 |
| Disk size | ~47 MB |
| Deploy time (scratch org) | ~3 minutes |

## Metadata Breakdown

| Type | Count | Description |
|------|-------|-------------|
| Apex Classes | 69 | Service controllers, batch processors, schedulable jobs, trigger handlers, VF controllers |
| Apex Triggers | 18 | Account, Contact, Opportunity, Lead, Case, Task, Event, Contract, Order |
| LWC Components | 130 | 80 full data-management components + 50 utility/service modules |
| Aura Components | 40 | Legacy manager components with controller/helper patterns |
| Custom Objects | 60 | Each with 30 fields (Text, Number, Currency, Date, Picklist, Lookup, etc.) |
| Custom Fields | 1,800 | Across all custom objects |
| Validation Rules | 180 | 3 per custom object |
| Flows | 50 | Record-triggered auto-launched flows |
| Visualforce Pages | 25 | Full CRUD pages with SLDS styling |
| Permission Sets | 30 | Object and field-level permissions |
| Profiles | 10 | Custom profiles with layout assignments |
| Static Resources | 10 | CSS/JS bundles (up to 5MB each) |
| Custom Labels | 500 | Internationalization labels |
| Layouts | 60 | Two-column page layouts for custom objects |
| FlexiPages | 20 | Lightning App Pages |
| List Views | 60 | One per custom object |

## Architecture

```
force-app/main/default/
├── classes/           # Apex: services, batch, scheduled, handlers, tests
├── triggers/          # Trigger framework (handler delegation pattern)
├── lwc/               # Lightning Web Components
├── aura/              # Aura components (legacy)
├── objects/           # Custom objects with fields, validation rules, list views
├── flows/             # Auto-launched record-triggered flows
├── pages/             # Visualforce pages
├── permissionsets/    # Permission sets
├── profiles/          # Custom profiles
├── staticresources/   # CSS/JS bundles
├── labels/            # Custom labels (500)
├── layouts/           # Page layouts
└── flexipages/        # Lightning app pages
```

## Apex Patterns Included

- **Service Controllers** (`Service_Module*_Controller`): `@AuraEnabled` methods with SOQL, DML, error handling, async processing
- **Batch Processors** (`BatchProcessor_Module*`): `Database.Batchable` with `Stateful`, callouts, error aggregation, email notifications
- **Schedulable Jobs** (`ScheduledJob_Process*`): `Schedulable` implementations with batch chaining
- **Trigger Handlers** (`Trigger_*Handler`): Delegated trigger pattern across all DML events
- **VF Controllers** (`ServicePage_*Controller`): Standard controller extension pattern

## LWC Patterns Included

- Wire service with `@wire` decorators
- Imperative Apex calls with error handling
- `NavigationMixin` for record navigation
- `lightning-datatable` with sorting, pagination, row actions
- Modal dialogs, toast notifications
- Search/filter with debouncing
- `@api` property exposure for App Builder

## Deploying

```bash
# To a scratch org
sf org create scratch -f config/project-scratch-def.json -a my-scratch
sf project deploy start --target-org my-scratch

# To any authorized org
sf project deploy start --target-org <alias-or-username>
```

## Org Limits

This project is sized to fit within standard scratch org limits:

- Apex code: ~1 MB (limit: 6 MB)
- Static resources: ~20 MB per file max 5 MB (limit: 250 MB total)
- Custom objects: 60 (limit: 200+ depending on edition)
- Fields per object: 30 (limit: 500)

## Scaling Up

To increase the project size beyond org-deployable limits (for testing local tooling only):

1. **Add more static resources**: Generate larger CSS/JS bundles (Salesforce limits each to 5MB, but local tooling doesn't care)
2. **Add more Apex classes**: Duplicate service modules (can't deploy past 6MB Apex limit)
3. **Add more custom objects/fields**: Increase field count per object

## License

Internal use only - Salesforce performance testing.
