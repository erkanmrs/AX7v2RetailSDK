/**
 * SAMPLE CODE NOTICE
 * 
 * THIS SAMPLE CODE IS MADE AVAILABLE AS IS.  MICROSOFT MAKES NO WARRANTIES, WHETHER EXPRESS OR IMPLIED,
 * OF FITNESS FOR A PARTICULAR PURPOSE, OF ACCURACY OR COMPLETENESS OF RESPONSES, OF RESULTS, OR CONDITIONS OF MERCHANTABILITY.
 * THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS SAMPLE CODE REMAINS WITH THE USER.
 * NO TECHNICAL SUPPORT IS PROVIDED.  YOU MAY NOT DISTRIBUTE THIS CODE UNLESS YOU HAVE A LICENSE AGREEMENT WITH MICROSOFT THAT ALLOWS YOU TO DO SO.
 */

///<reference path='Commerce.Core.d.ts'/>

// after the DOM content is loaded we register our extensions: operations, entities, managers, factories, etc.
document.addEventListener('DOMContentLoaded', (event: Event) => {
    // operations
    var operationsManager: Commerce.Operations.OperationsManager = Commerce.Operations.OperationsManager.instance;
    operationsManager.registerOperationHandler({
        id: <number>Custom.Entities.RetailOperationEx.AddCrossLoyaltyCard,
        handler: new Custom.Operations.AddCrossLoyaltyCardOperationHandler(),
        validators: [
            { validatorFunctions: [Commerce.Operations.Validators.notAllowedInNonDrawerModeOperationValidator] }
        ],
    });

    // entities

    // factories
    Commerce.Model.Managers.Factory = new Custom.Managers.ExtendedManagerFactory(Commerce.Config.retailServerUrl, "en-US");
});
