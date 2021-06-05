
export function nodeApiUrl(): string {
    const projectId = process.env.GCLOUD_PROJECT;
    switch (projectId) {
        case 'pao-uat-6b24c':
        //prod
            return 'http://35.188.204.46:60702';
        case 'pao-uat-cb20c':
        //uat
            return 'http://34.66.36.63:60702';
        case 'pao-app':
        //dev
            return 'http://18.223.115.6:60702';
        default:
            break;
    }

    return 'Naaani?!?';
}