/// <reference types="@capacitor/cli" />
import type { PluginListenerHandle } from '@capacitor/core';

// eslint-disable-next-line @typescript-eslint/no-empty-interface
export interface WatchPlugin {
  /**
   * Listen for a command from the watch
   */
  addListener(
    eventName: 'runCommand',
    listenerFunc: (data: { command: string }) => void
  ): Promise<PluginListenerHandle> & PluginListenerHandle;

  /**
   * Replaces the current watch UI with watchUI
   */
  updateWatchUI(options: { watchUI: string }): Promise<void>;

  /**
   * Updates the watch's state data
   */
  updateWatchData(options: { data: { [key: string]: string } }): Promise<void>;

  /**
   * Sets the watch's state data
   */
  setWatchStateData(options: { data: { [key: string]: any } }): Promise<void>;

  /**
   * Sets a specific key-value pair in the watch's state data
   */
  setWatchStateDataByKey(options: { key: string, value: any }): Promise<void>;

  /**
   * Retrieves the watch's state data
   */
  getWatchStateData(): Promise<{ data: { [key: string]: any } }>;

  /**
   * Retrieves a specific value from the watch's state data by key
   */
  getWatchStateDataByKey(options: { key: string }): Promise<{ value: any }>;
}
