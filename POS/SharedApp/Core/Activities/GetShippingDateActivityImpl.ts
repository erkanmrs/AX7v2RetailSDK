/**
 * SAMPLE CODE NOTICE
 * 
 * THIS SAMPLE CODE IS MADE AVAILABLE AS IS.  MICROSOFT MAKES NO WARRANTIES, WHETHER EXPRESS OR IMPLIED,
 * OF FITNESS FOR A PARTICULAR PURPOSE, OF ACCURACY OR COMPLETENESS OF RESPONSES, OF RESULTS, OR CONDITIONS OF MERCHANTABILITY.
 * THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS SAMPLE CODE REMAINS WITH THE USER.
 * NO TECHNICAL SUPPORT IS PROVIDED.  YOU MAY NOT DISTRIBUTE THIS CODE UNLESS YOU HAVE A LICENSE AGREEMENT WITH MICROSOFT THAT ALLOWS YOU TO DO SO.
 */

///<reference path='../../Views/Controls/GetShippingDateDialog.ts'/>
///<reference path='ModalDialogHelper.ts'/>

module Commerce.Activities {
    "use strict";

    GetShippingDateActivity.prototype.execute = function (): IVoidAsyncResult {
        var self = <GetShippingDateActivity>(this);

        var getShippingDateDialog = new Controls.GetShippingDateDialog();

        getShippingDateDialog.show(self.context, false)
            .on(DialogResult.OK, (activityResponse: GetShippingDateActivityResponse) => {
                self.response = activityResponse;
            });

        return ModalDialogHelper.toVoidAsyncResult(getShippingDateDialog, true);
    };
}