import { NgModule } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule, MatButton } from '@angular/material/button';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';

@NgModule({
  imports: [
    NoopAnimationsModule,
    MatButtonModule,
    MatCardModule
  ],
  exports: [
    NoopAnimationsModule,
    MatButtonModule,
    MatCardModule
  ]
})
export class MaterialModule { }
