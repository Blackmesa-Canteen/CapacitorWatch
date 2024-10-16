import { WebPlugin } from '@capacitor/core';

import type { WatchPlugin } from './definitions';

export class WatchWeb extends WebPlugin implements WatchPlugin {
  async setWatchUI(_options: { watchUI: string }): Promise<void> {
    return Promise.reject('method not implemented on web');
  }

  async updateWatchUI(_options: { watchUI: string }): Promise<void> {
    return Promise.reject('method not implemented on web');
  }

  async updateWatchData(_options: { data: { [key: string]: string } }): Promise<void> {
    return Promise.reject('method not implemented on web');
  }

  async setWatchStateData(_options: { data: { [key: string]: any } }): Promise<void> {
    return Promise.reject('method not implemented on web');
  }

  async setWatchStateDataByKey(_options: { key: string, value: any }): Promise<void> {
    return Promise.reject('method not implemented on web');
  }

  async getWatchStateData(): Promise<{ data: { [key: string]: any } }> {
    return Promise.reject('method not implemented on web');
  }

  async getWatchStateDataByKey(_options: { key: string }): Promise<{ value: any }> {
    return Promise.reject('method not implemented on web');
  }
}
