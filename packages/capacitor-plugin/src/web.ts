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

  async updateWatchStateData(_options: { data: { [key: string]: any } }): Promise<void> {
    return Promise.reject('method not implemented on web');
  }

  async updateWatchStateDataByKey(_options: { key: string, value: any }): Promise<void> {
    return Promise.reject('method not implemented on web');
  }

  async getWatchStateData(): Promise<{ [key: string]: any }> {
    return Promise.reject('method not implemented on web');
  }
}
