import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';

import { AppStore } from '../../app.store';
import { ItemStore } from '../../shared/stores/item.store';
import { Person } from '../../shared/models/person';

@Injectable()
export class PersonStore {

  get list(): Observable<Person[]> {
    return this.appStore.map(appStore => {
      return Object.keys(appStore.person).map(id => appStore.person[id])
        .filter((person: Person) => !!person)
        .sort((a: Person, b: Person) => b.id - a.id);
    });
  }

  constructor(private appStore: AppStore) {
    this.mockSetup();
  }

  mockSetup() {
    [
      new Person('e_ntyo'),
      new Person('akameco')
    ].forEach(p => this.insert(p));
  }

  get(id: number): Observable<Person> {
    return this.appStore.map(appStore => appStore.person[id]);
  }

  insert(person: Person): void {
    const store = this.appStore.snapshot;
    person.id = Object.keys(store.person).length;
    store.person[person.id] = person;
    this.appStore.patchValue(store);
  }

  update(id: number, person: Person): void {
    const store = this.appStore.snapshot;
    store.person[person.id] = person;
    this.appStore.patchValue(store);
  }

  delete(id: number): void {
    const store = this.appStore.snapshot;
    store.person[id] = undefined;
    this.appStore.patchValue(store);

    // TODO: personに紐付いたitemの削除をする
  }
}
