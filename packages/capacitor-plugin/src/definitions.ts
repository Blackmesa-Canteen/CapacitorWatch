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
  ): Promise<PluginListenerHandle>;

  /**
   * Replaces the current watch UI with watchUI
   */
  updateWatchUI(options: { watchUI: string }): Promise<void>;

  /**
   * Updates the watch's state data
   */
  updateWatchData(options: { data: { [key: string]: string } }): Promise<void>;

  /**
   * Updates the entire watch state data
   */
  updateWatchStateData(options: { data: { [key: string]: any } }): Promise<void>;

  /**
   * Updates a specific key-value pair in the watch's state data
   */
  updateWatchStateDataByKey(options: { key: string, value: any }): Promise<void>;

    /**
     * Get the current state data of the watch
     */
  getWatchStateData(): Promise<{ [key: string]: any }>;
}
