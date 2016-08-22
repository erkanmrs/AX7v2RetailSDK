/**
 * SAMPLE CODE NOTICE
 * 
 * THIS SAMPLE CODE IS MADE AVAILABLE AS IS.  MICROSOFT MAKES NO WARRANTIES, WHETHER EXPRESS OR IMPLIED,
 * OF FITNESS FOR A PARTICULAR PURPOSE, OF ACCURACY OR COMPLETENESS OF RESPONSES, OF RESULTS, OR CONDITIONS OF MERCHANTABILITY.
 * THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS SAMPLE CODE REMAINS WITH THE USER.
 * NO TECHNICAL SUPPORT IS PROVIDED.  YOU MAY NOT DISTRIBUTE THIS CODE UNLESS YOU HAVE A LICENSE AGREEMENT WITH MICROSOFT THAT ALLOWS YOU TO DO SO.
 */

namespace Contoso
{
    namespace Commerce.HardwareStation.Peripherals.PaymentTerminal
    {
        using System.Composition;
        using Microsoft.Dynamics.Commerce.HardwareStation.Peripherals;

        /// <summary>
        ///  Network-based payment terminal class which handles the payment workflow.
        /// </summary>
        [Export(PeripheralType.Network, typeof(IPaymentTerminal))]
        public class NetworkPaymentTerminal : PaymentTerminalBase
        {
        }
    }
}
