export enum TemplateType {
	offer = 'offer', access = 'access'
}


export interface Template {
    id: string,
    hash: string,
    raw: Object
    kind: TemplateType;
}
