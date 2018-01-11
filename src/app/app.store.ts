import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs/BehaviorSubject';

import { Item } from './shared/models/item';
import { Person } from './shared/models/person';

export interface AppStoreSnapshot {
  item?: {
    [id: number]: Item,
  };
  person?: {
    [id: number]: Person,
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
      person: {}
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
