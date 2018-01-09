import { NgModule } from '@angular/core';

import { ItemStore } from './stores/item.store';
import { PersonStore } from './stores/person.store';

@NgModule({
  imports: [],
  exports: [],
  declarations: []
})
export class SharedModule {
  // forRoot() is used to add application/singleton services.
  // https://stackoverflow.com/questions/39653072/how-to-use-forroot-within-feature-modules-hierarchy
  static forRoot() {
    return {
      ngModule: RootSharedModule,
    };
  }
}

@NgModule({
  imports: [
    SharedModule
  ],
  exports: [
    SharedModule
  ],
  providers: [
    ItemStore,
    PersonStore
  ],
})
export class RootSharedModule {
}
