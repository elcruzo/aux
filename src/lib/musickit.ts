declare global {
  interface Window {
    MusicKit: any;
  }
}

export async function configureMusicKit(developerToken: string): Promise<any> {
  return new Promise((resolve, reject) => {
    if (typeof window === 'undefined') {
      reject(new Error('MusicKit can only be initialized in the browser'));
      return;
    }

    if (!window.MusicKit) {
      reject(new Error('MusicKit not loaded'));
      return;
    }

    try {
      const music = window.MusicKit.configure({
        developerToken,
        app: {
          name: 'Aux',
          build: '1.0.0',
        },
      });

      resolve(music);
    } catch (error) {
      reject(error);
    }
  });
}

export async function authorizeMusicKit(music: any): Promise<string> {
  try {
    const musicUserToken = await music.authorize();
    return musicUserToken;
  } catch (error) {
    console.error('MusicKit authorization error:', error);
    throw error;
  }
}

export function getMusicInstance(): any {
  if (typeof window === 'undefined' || !window.MusicKit) {
    throw new Error('MusicKit not available');
  }
  return window.MusicKit.getInstance();
}