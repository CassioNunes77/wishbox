/**
 * Service para gerenciar armazenamento local (localStorage)
 */

export class StorageService {
  private static prefix = 'wishbox_';

  static setItem(key: string, value: any): boolean {
    try {
      if (typeof window === 'undefined') return false;
      const serialized = JSON.stringify(value);
      localStorage.setItem(`${this.prefix}${key}`, serialized);
      return true;
    } catch (error) {
      console.error('StorageService: Error setting item:', error);
      return false;
    }
  }

  static getItem<T>(key: string, defaultValue?: T): T | null {
    try {
      if (typeof window === 'undefined') return defaultValue || null;
      const item = localStorage.getItem(`${this.prefix}${key}`);
      if (item === null) return defaultValue || null;
      return JSON.parse(item) as T;
    } catch (error) {
      console.error('StorageService: Error getting item:', error);
      return defaultValue || null;
    }
  }

  static removeItem(key: string): boolean {
    try {
      if (typeof window === 'undefined') return false;
      localStorage.removeItem(`${this.prefix}${key}`);
      return true;
    } catch (error) {
      console.error('StorageService: Error removing item:', error);
      return false;
    }
  }

  static clear(): boolean {
    try {
      if (typeof window === 'undefined') return false;
      const keys = Object.keys(localStorage);
      keys.forEach((key) => {
        if (key.startsWith(this.prefix)) {
          localStorage.removeItem(key);
        }
      });
      return true;
    } catch (error) {
      console.error('StorageService: Error clearing:', error);
      return false;
    }
  }
}
