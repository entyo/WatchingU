import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs/BehaviorSubject';

import { Item } from '../models/item';

export interface AppStoreSnapshot {
  item?: {
    [id: number]: Item,
  };
}

@Injectable()
export class AppStore extends BehaviorSubject<AppStoreSnapshot> {

  private _snapshot: AppStoreSnapshot;

  get snapshot() {
    return this._snapshot;
  }

  constructor() {
    super({
      item: {},
    });
    this.subscribe(snapshot => {
      this._snapshot = snapshot;
    });
  }

  patchValue(value: AppStoreSnapshot) {
    const snapshot = Object.assign({}, this._snapshot, value);
    this.next(snapshot);
  }
}
