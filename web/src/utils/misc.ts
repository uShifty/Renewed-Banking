import { currency } from "../store/stores";
import { popupDetails } from "../store/stores";

export const isEnvBrowser = (): boolean => !(window as any).invokeNative;

let activeCurrency: string
currency.subscribe((value: string) => {
    activeCurrency = value;
});

export function formatMoney(number: number): string {
    return number.toLocaleString('en-US', { style: 'currency', currency: activeCurrency });
}

export function closePopup() {
    popupDetails.update((val: any) => ({
        ...val,
        actionType: ""
    }));
}

export function validateAccountID(inputField: any): string {
    const regex = /^[A-Za-z0-9]+$/;
    const inputValue = inputField.value;
    const isValid = regex.test(inputValue);
  
    if (!isValid) {
      inputField.value = inputValue.replace(/[^A-Za-z0-9]+/g, ''); // Remove invalid characters
    }
  
    inputField.value = inputField.value.slice(0, 15);
    return inputField.value;
}