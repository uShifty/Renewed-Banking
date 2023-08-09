export interface PlayerData {
    name: string,
    id: string
}
export interface transactionType {
    title: string,
    trans_id: string,
    account: string,
    amount: number,
    trans_type: string,
    receiver: string,
    issuer: string,
    time: number,
    message: string,
}

export interface accountType {
    id: string,
    type: string,
    name: string,
    amount: number, 
    citizen_id: string,
    transactions: transactionType[]
}

export interface popupDetails {
    account: accountType,
    actionType: string,
}