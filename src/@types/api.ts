export enum PERMISSIONS {
    CAN_ANNOTATE = 'can_annotate',
    CAN_VIEW_ANNOTATIONS_ALL = 'can_view_annotations_all',
    CAN_VIEW_ANNOTATIONS_SELF = 'can_view_annotations_self',
}

export interface Permissions {
    [index: string]: boolean | undefined;
    [PERMISSIONS.CAN_ANNOTATE]?: boolean;
    [PERMISSIONS.CAN_VIEW_ANNOTATIONS_ALL]?: boolean;
    [PERMISSIONS.CAN_VIEW_ANNOTATIONS_SELF]?: boolean;
}
