/**
 * Runtime storage interface expected from the platform or app bootstrap.
 */
export interface AppStorageRuntime {
  get<T>(key: string): T | null;
  setOrCreate<T>(key: string, value: T): void;
  set?<T>(key: string, value: T): void;
}

export interface AppScopeApp {
  storage?: AppStorageRuntime;
}

declare const $app: AppScopeApp | undefined;

export class AppStorage {
  static get<T>(key: string): T | null {
    try {
      const runtime = $app && $app.storage ? $app.storage : undefined;
      if (!runtime) return null;
      return runtime.get<T>(key);
    } catch (e) {
      return null;
    }
  }

  static setOrCreate<T>(key: string, value: T): void {
    try {
      const runtime = $app && $app.storage ? $app.storage : undefined;
      if (!runtime) return;
      if (typeof runtime.setOrCreate === 'function') {
        runtime.setOrCreate<T>(key, value);
      } else if (typeof runtime.set === 'function') {
        runtime.set(key, value);
      }
    } catch (e) {
      // ignore
    }
  }
}
